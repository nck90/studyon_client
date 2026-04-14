import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@Controller({ version: '1' })
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Roles(UserRole.STUDENT)
  @Get('student/notifications')
  studentNotifications(@CurrentUser() user: JwtPayload) {
    return this.notificationsService.studentNotifications(user.sub);
  }

  @Roles(UserRole.STUDENT)
  @Post('student/notifications/:notificationId/read')
  read(
    @CurrentUser() user: JwtPayload,
    @Param('notificationId') notificationId: string,
  ) {
    return this.notificationsService.readNotification(user.sub, notificationId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/notifications')
  listAdmin() {
    return this.notificationsService.listAdmin();
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/notifications/:notificationId')
  getAdmin(@Param('notificationId') notificationId: string) {
    return this.notificationsService.getAdmin(notificationId);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/notifications')
  create(@CurrentUser() user: JwtPayload, @Body() body: CreateNotificationDto) {
    return this.notificationsService.createAdmin({
      actorUserId: user.sub,
      notificationType: body.notificationType,
      channel: body.channel,
      title: body.title,
      body: body.body,
      targetScope: body.targetScope,
      scheduledAt: body.scheduledAt,
    });
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Post('admin/notifications/:notificationId/send')
  send(@Param('notificationId') notificationId: string) {
    return this.notificationsService.send(notificationId);
  }
}
