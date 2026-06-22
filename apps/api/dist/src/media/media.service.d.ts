import { MediaAssetKind } from '@prisma/client';
import { PrismaService } from "../database/prisma.service";
export declare class MediaService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    uploadStudentMedia(studentId: string, kind: MediaAssetKind, file: {
        originalname?: string;
        mimetype?: string;
        size?: number;
        buffer?: Buffer;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            createdAt: Date;
            studentId: string;
            kind: import("@prisma/client").$Enums.MediaAssetKind;
            originalName: string;
            mimeType: string;
            byteSize: number;
            storageKey: string;
            publicUrl: string;
        };
        meta: {};
    }>;
    deleteStudentMedia(studentId: string, mediaId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
    deleteStudentMediaQuiet(studentId: string, mediaId: string): Promise<void>;
    getStudentMediaContent(studentId: string, mediaId: string): Promise<{
        stream: NodeJS.ReadableStream;
        mimeType: string;
    }>;
    getPublicMediaContent(mediaId: string): Promise<{
        stream: NodeJS.ReadableStream;
        mimeType: string;
    }>;
    resolveStudentAssets(studentId: string, mediaIds: (string | null)[]): Promise<{
        [k: string]: {
            id: string;
            createdAt: Date;
            studentId: string;
            kind: import("@prisma/client").$Enums.MediaAssetKind;
            originalName: string;
            mimeType: string;
            byteSize: number;
            storageKey: string;
            publicUrl: string;
        };
    }>;
    private safeExtension;
    private matchesImageSignature;
}
