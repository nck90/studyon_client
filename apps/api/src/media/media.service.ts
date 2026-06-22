import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { MediaAssetKind } from '@prisma/client';
import { createReadStream, promises as fs } from 'node:fs';
import { join, extname } from 'node:path';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '@/database/prisma.service';

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const UPLOAD_ROOT = process.env.MEDIA_UPLOAD_DIR ?? 'uploads/student-media';
const ALLOWED_IMAGE_MIME_TYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
]);

@Injectable()
export class MediaService {
  constructor(private readonly prisma: PrismaService) {}

  async uploadStudentMedia(
    studentId: string,
    kind: MediaAssetKind,
    file: {
      originalname?: string;
      mimetype?: string;
      size?: number;
      buffer?: Buffer;
    },
  ) {
    if (!Object.values(MediaAssetKind).includes(kind)) {
      throw new BadRequestException('지원하지 않는 미디어 종류입니다.');
    }
    if (!file?.buffer || file.buffer.length === 0) {
      throw new BadRequestException('업로드할 파일이 필요합니다.');
    }
    const mimeType = file.mimetype ?? '';
    if (!ALLOWED_IMAGE_MIME_TYPES.has(mimeType)) {
      throw new BadRequestException('이미지 파일만 업로드할 수 있습니다.');
    }
    if (!this.matchesImageSignature(file.buffer, mimeType)) {
      throw new BadRequestException('이미지 파일 형식이 올바르지 않습니다.');
    }
    const byteSize = file.size ?? file.buffer.length;
    if (byteSize > MAX_IMAGE_BYTES) {
      throw new BadRequestException(
        '이미지는 5MB 이하만 업로드할 수 있습니다.',
      );
    }

    await fs.mkdir(UPLOAD_ROOT, { recursive: true });
    const assetId = randomUUID();
    const extension = this.safeExtension(file.originalname, mimeType);
    const storageKey = `${studentId}/${kind.toLowerCase()}-${assetId}${extension}`;
    const diskPath = join(UPLOAD_ROOT, storageKey);
    await fs.mkdir(join(UPLOAD_ROOT, studentId), { recursive: true });
    await fs.writeFile(diskPath, file.buffer);

    const asset = await this.prisma.mediaAsset.create({
      data: {
        id: assetId,
        studentId,
        kind,
        originalName: file.originalname?.slice(0, 255) || `image${extension}`,
        mimeType,
        byteSize,
        storageKey,
        publicUrl: `/api/v1/student/media/${assetId}/content`,
      },
    });

    return { success: true, data: asset, meta: {} };
  }

  async deleteStudentMedia(studentId: string, mediaId: string) {
    const asset = await this.prisma.mediaAsset.findUnique({
      where: { id: mediaId },
    });
    if (!asset) {
      throw new NotFoundException('미디어를 찾을 수 없습니다.');
    }
    if (asset.studentId !== studentId) {
      throw new ForbiddenException('삭제할 수 없는 미디어입니다.');
    }
    await this.prisma.mediaAsset.delete({ where: { id: mediaId } });
    await fs.unlink(join(UPLOAD_ROOT, asset.storageKey)).catch(() => undefined);
    return { success: true, data: { deleted: true }, meta: {} };
  }

  async deleteStudentMediaQuiet(studentId: string, mediaId: string) {
    const asset = await this.prisma.mediaAsset.findUnique({
      where: { id: mediaId },
    });
    if (!asset || asset.studentId !== studentId) {
      return;
    }
    await this.prisma.mediaAsset.delete({ where: { id: mediaId } });
    await fs.unlink(join(UPLOAD_ROOT, asset.storageKey)).catch(() => undefined);
  }

  async getStudentMediaContent(
    studentId: string,
    mediaId: string,
  ): Promise<{ stream: NodeJS.ReadableStream; mimeType: string }> {
    const asset = await this.prisma.mediaAsset.findUnique({
      where: { id: mediaId },
    });
    if (!asset) {
      throw new NotFoundException('미디어를 찾을 수 없습니다.');
    }
    if (asset.studentId !== studentId) {
      throw new ForbiddenException('조회할 수 없는 미디어입니다.');
    }
    return {
      stream: createReadStream(join(UPLOAD_ROOT, asset.storageKey)),
      mimeType: asset.mimeType,
    };
  }

  async getPublicMediaContent(
    mediaId: string,
  ): Promise<{ stream: NodeJS.ReadableStream; mimeType: string }> {
    const asset = await this.prisma.mediaAsset.findUnique({
      where: { id: mediaId },
    });
    if (!asset) {
      throw new NotFoundException('미디어를 찾을 수 없습니다.');
    }
    return {
      stream: createReadStream(join(UPLOAD_ROOT, asset.storageKey)),
      mimeType: asset.mimeType,
    };
  }

  async resolveStudentAssets(studentId: string, mediaIds: (string | null)[]) {
    const ids = mediaIds.filter((id): id is string => Boolean(id));
    if (ids.length === 0) return {};
    const assets = await this.prisma.mediaAsset.findMany({
      where: { studentId, id: { in: ids } },
    });
    return Object.fromEntries(assets.map((asset) => [asset.id, asset]));
  }

  private safeExtension(originalName: string | undefined, mimeType: string) {
    const ext = extname(originalName ?? '').toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.webp', '.gif'].includes(ext)) return ext;
    if (mimeType === 'image/png') return '.png';
    if (mimeType === 'image/webp') return '.webp';
    if (mimeType === 'image/gif') return '.gif';
    return '.jpg';
  }

  private matchesImageSignature(buffer: Buffer, mimeType: string) {
    if (mimeType === 'image/jpeg') {
      return buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
    }
    if (mimeType === 'image/png') {
      return (
        buffer[0] === 0x89 &&
        buffer[1] === 0x50 &&
        buffer[2] === 0x4e &&
        buffer[3] === 0x47
      );
    }
    if (mimeType === 'image/webp') {
      return (
        buffer.toString('ascii', 0, 4) === 'RIFF' &&
        buffer.toString('ascii', 8, 12) === 'WEBP'
      );
    }
    if (mimeType === 'image/gif') {
      const signature = buffer.toString('ascii', 0, 6);
      return signature === 'GIF87a' || signature === 'GIF89a';
    }
    return false;
  }
}
