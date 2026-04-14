import { Controller, Query, Sse } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Public } from '@/common/decorators/public.decorator';
import { EventsService } from './events.service';

function parseChannels(value?: string) {
  return value
    ?.split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

@ApiTags('events')
@Controller({ path: 'events', version: '1' })
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Public()
  @Sse('public')
  streamPublic(@Query('channels') channels?: string) {
    return this.eventsService.streamPublic(parseChannels(channels));
  }

  @ApiBearerAuth()
  @Sse('me')
  streamMe(
    @CurrentUser() user: JwtPayload,
    @Query('channels') channels?: string,
  ) {
    return this.eventsService.streamUser(user.sub, parseChannels(channels));
  }
}
