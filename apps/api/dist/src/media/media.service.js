"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
const node_crypto_1 = require("node:crypto");
const prisma_service_1 = require("../database/prisma.service");
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const UPLOAD_ROOT = process.env.MEDIA_UPLOAD_DIR ?? 'uploads/student-media';
const ALLOWED_IMAGE_MIME_TYPES = new Set([
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
]);
let MediaService = class MediaService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async uploadStudentMedia(studentId, kind, file) {
        if (!Object.values(client_1.MediaAssetKind).includes(kind)) {
            throw new common_1.BadRequestException('지원하지 않는 미디어 종류입니다.');
        }
        if (!file?.buffer || file.buffer.length === 0) {
            throw new common_1.BadRequestException('업로드할 파일이 필요합니다.');
        }
        const mimeType = file.mimetype ?? '';
        if (!ALLOWED_IMAGE_MIME_TYPES.has(mimeType)) {
            throw new common_1.BadRequestException('이미지 파일만 업로드할 수 있습니다.');
        }
        if (!this.matchesImageSignature(file.buffer, mimeType)) {
            throw new common_1.BadRequestException('이미지 파일 형식이 올바르지 않습니다.');
        }
        const byteSize = file.size ?? file.buffer.length;
        if (byteSize > MAX_IMAGE_BYTES) {
            throw new common_1.BadRequestException('이미지는 5MB 이하만 업로드할 수 있습니다.');
        }
        await node_fs_1.promises.mkdir(UPLOAD_ROOT, { recursive: true });
        const assetId = (0, node_crypto_1.randomUUID)();
        const extension = this.safeExtension(file.originalname, mimeType);
        const storageKey = `${studentId}/${kind.toLowerCase()}-${assetId}${extension}`;
        const diskPath = (0, node_path_1.join)(UPLOAD_ROOT, storageKey);
        await node_fs_1.promises.mkdir((0, node_path_1.join)(UPLOAD_ROOT, studentId), { recursive: true });
        await node_fs_1.promises.writeFile(diskPath, file.buffer);
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
    async deleteStudentMedia(studentId, mediaId) {
        const asset = await this.prisma.mediaAsset.findUnique({
            where: { id: mediaId },
        });
        if (!asset) {
            throw new common_1.NotFoundException('미디어를 찾을 수 없습니다.');
        }
        if (asset.studentId !== studentId) {
            throw new common_1.ForbiddenException('삭제할 수 없는 미디어입니다.');
        }
        await this.prisma.mediaAsset.delete({ where: { id: mediaId } });
        await node_fs_1.promises.unlink((0, node_path_1.join)(UPLOAD_ROOT, asset.storageKey)).catch(() => undefined);
        return { success: true, data: { deleted: true }, meta: {} };
    }
    async deleteStudentMediaQuiet(studentId, mediaId) {
        const asset = await this.prisma.mediaAsset.findUnique({
            where: { id: mediaId },
        });
        if (!asset || asset.studentId !== studentId) {
            return;
        }
        await this.prisma.mediaAsset.delete({ where: { id: mediaId } });
        await node_fs_1.promises.unlink((0, node_path_1.join)(UPLOAD_ROOT, asset.storageKey)).catch(() => undefined);
    }
    async getStudentMediaContent(studentId, mediaId) {
        const asset = await this.prisma.mediaAsset.findUnique({
            where: { id: mediaId },
        });
        if (!asset) {
            throw new common_1.NotFoundException('미디어를 찾을 수 없습니다.');
        }
        if (asset.studentId !== studentId) {
            throw new common_1.ForbiddenException('조회할 수 없는 미디어입니다.');
        }
        return {
            stream: (0, node_fs_1.createReadStream)((0, node_path_1.join)(UPLOAD_ROOT, asset.storageKey)),
            mimeType: asset.mimeType,
        };
    }
    async getPublicMediaContent(mediaId) {
        const asset = await this.prisma.mediaAsset.findUnique({
            where: { id: mediaId },
        });
        if (!asset) {
            throw new common_1.NotFoundException('미디어를 찾을 수 없습니다.');
        }
        return {
            stream: (0, node_fs_1.createReadStream)((0, node_path_1.join)(UPLOAD_ROOT, asset.storageKey)),
            mimeType: asset.mimeType,
        };
    }
    async resolveStudentAssets(studentId, mediaIds) {
        const ids = mediaIds.filter((id) => Boolean(id));
        if (ids.length === 0)
            return {};
        const assets = await this.prisma.mediaAsset.findMany({
            where: { studentId, id: { in: ids } },
        });
        return Object.fromEntries(assets.map((asset) => [asset.id, asset]));
    }
    safeExtension(originalName, mimeType) {
        const ext = (0, node_path_1.extname)(originalName ?? '').toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.webp', '.gif'].includes(ext))
            return ext;
        if (mimeType === 'image/png')
            return '.png';
        if (mimeType === 'image/webp')
            return '.webp';
        if (mimeType === 'image/gif')
            return '.gif';
        return '.jpg';
    }
    matchesImageSignature(buffer, mimeType) {
        if (mimeType === 'image/jpeg') {
            return buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
        }
        if (mimeType === 'image/png') {
            return (buffer[0] === 0x89 &&
                buffer[1] === 0x50 &&
                buffer[2] === 0x4e &&
                buffer[3] === 0x47);
        }
        if (mimeType === 'image/webp') {
            return (buffer.toString('ascii', 0, 4) === 'RIFF' &&
                buffer.toString('ascii', 8, 12) === 'WEBP');
        }
        if (mimeType === 'image/gif') {
            const signature = buffer.toString('ascii', 0, 6);
            return signature === 'GIF87a' || signature === 'GIF89a';
        }
        return false;
    }
};
exports.MediaService = MediaService;
exports.MediaService = MediaService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MediaService);
//# sourceMappingURL=media.service.js.map