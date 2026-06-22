import { MediaAssetKind } from '@prisma/client';
import type { Response } from 'express';
import { JwtPayload } from "../auth/types/jwt-payload.type";
import { MediaService } from './media.service';
export declare class MediaController {
    private readonly mediaService;
    constructor(mediaService: MediaService);
    upload(user: JwtPayload, kind: MediaAssetKind | undefined, file: unknown): Promise<{
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
    content(mediaId: string, response: Response): Promise<void>;
    delete(user: JwtPayload, mediaId: string): Promise<{
        success: boolean;
        data: {
            deleted: boolean;
        };
        meta: {};
    }>;
}
