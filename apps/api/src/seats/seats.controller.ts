import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { SeatStatus, UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { AssignSeatDto } from './dto/assign-seat.dto';
import { SeatChangeRequestDto } from './dto/seat-change-request.dto';
import { SeatsService } from './seats.service';

@ApiTags('seats')
@ApiBearerAuth()
@Controller({ version: '1' })
export class SeatsController {
  constructor(private readonly seatsService: SeatsService) {}

  @Roles(UserRole.STUDENT)
  @Get('student/seats/my')
  mySeat(@CurrentUser() user: JwtPayload) {
    return this.seatsService.getMySeat(user.studentId!);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/seats/map')
  seatMap(@Query('zone') zone?: string) {
    return this.seatsService.getSeatMap(zone);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/seats/available')
  available(@Query('zone') zone?: string) {
    return this.seatsService.getAvailableSeats(zone);
  }

  @Roles(UserRole.STUDENT)
  @Post('student/seat-change-requests')
  requestChange(
    @CurrentUser() user: JwtPayload,
    @Body() dto: SeatChangeRequestDto,
  ) {
    return this.seatsService.requestSeatChange(
      user.studentId!,
      dto.toSeatId,
      dto.reason,
    );
  }

  @Roles(UserRole.STUDENT)
  @Get('student/seat-change-requests')
  myRequests(@CurrentUser() user: JwtPayload) {
    return this.seatsService.mySeatChangeRequests(user.studentId!);
  }

  @Roles(UserRole.ADMIN, UserRole.DIRECTOR)
  @Get('admin/seats')
  adminSeats(
    @Query('zone') zone?: string,
    @Query('status') status?: SeatStatus,
  ) {
    return this.seatsService.listAdmin(zone, status);
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seats')
  createSeat(
    @CurrentUser() user: JwtPayload,
    @Body('seatNo') seatNo: string,
    @Body('zone') zone?: string,
  ) {
    return this.seatsService.createSeat(seatNo, zone, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Patch('admin/seats/:seatId')
  updateSeat(
    @CurrentUser() user: JwtPayload,
    @Param('seatId') seatId: string,
    @Query('status') status?: SeatStatus,
    @Query('zone') zone?: string,
  ) {
    return this.seatsService.updateSeat(seatId, status, zone, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seats/:seatId/assign')
  assign(
    @CurrentUser() user: JwtPayload,
    @Param('seatId') seatId: string,
    @Body() dto: AssignSeatDto,
  ) {
    return this.seatsService.assign(
      seatId,
      dto.studentId,
      dto.assignmentType,
      user.sub,
    );
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seats/:seatId/lock')
  lock(@CurrentUser() user: JwtPayload, @Param('seatId') seatId: string) {
    return this.seatsService.lock(seatId, true, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seats/:seatId/unlock')
  unlock(@CurrentUser() user: JwtPayload, @Param('seatId') seatId: string) {
    return this.seatsService.lock(seatId, false, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Delete('admin/seats/:seatId')
  deleteSeat(@CurrentUser() user: JwtPayload, @Param('seatId') seatId: string) {
    return this.seatsService.deleteSeat(seatId, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Get('admin/seat-change-requests')
  listRequests() {
    return this.seatsService.listChangeRequests();
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seat-change-requests/:requestId/approve')
  approve(
    @CurrentUser() user: JwtPayload,
    @Param('requestId') requestId: string,
  ) {
    return this.seatsService.reviewRequest(requestId, true, user.sub);
  }

  @Roles(UserRole.ADMIN)
  @Post('admin/seat-change-requests/:requestId/reject')
  reject(
    @CurrentUser() user: JwtPayload,
    @Param('requestId') requestId: string,
  ) {
    return this.seatsService.reviewRequest(requestId, false, user.sub);
  }
}
