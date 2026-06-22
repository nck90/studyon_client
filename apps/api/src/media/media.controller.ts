import {
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  Res,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { MediaAssetKind, UserRole } from '@prisma/client';
import type { Response } from 'express';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Public } from '@/common/decorators/public.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { MediaService } from './media.service';

@ApiTags('student-media')
@ApiBearerAuth()
@Roles(UserRole.STUDENT)
@Controller({ path: 'student/media', version: '1' })
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post()
  @UseInterceptors(FileInterceptor('file'))
  upload(
    @CurrentUser() user: JwtPayload,
    @Query('kind') kind: MediaAssetKind = MediaAssetKind.HOME_BACKGROUND,
    @UploadedFile() file: unknown,
  ) {
    return this.mediaService.uploadStudentMedia(
      user.studentId!,
      kind,
      file as {
        originalname?: string;
        mimetype?: string;
        size?: number;
        buffer?: Buffer;
      },
    );
  }

  @Get(':mediaId/content')
  @Public()
  @Roles()
  async content(@Param('mediaId') mediaId: string, @Res() response: Response) {
    const content = await this.mediaService.getPublicMediaContent(mediaId);
    response.setHeader('Content-Type', content.mimeType);
    content.stream.pipe(response);
  }

  @Delete(':mediaId')
  delete(@CurrentUser() user: JwtPayload, @Param('mediaId') mediaId: string) {
    return this.mediaService.deleteStudentMedia(user.studentId!, mediaId);
  }
}
