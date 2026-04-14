import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Public } from './decorators/public.decorator';

const SUBJECTS = ['국어', '영어', '수학', '과학', '사회', '한국사', '기타'];

@ApiTags('common')
@Public()
@Controller({ path: 'common', version: '1' })
export class CommonController {
  @Get('subjects')
  getSubjects() {
    return { success: true, data: SUBJECTS, meta: {} };
  }

  @Get('codes')
  getCodes(@Query('type') type?: string) {
    const codes: Record<string, string[]> = {
      attendance_status: [
        'NOT_CHECKED_IN',
        'CHECKED_IN',
        'CHECKED_OUT',
        'ABSENT',
      ],
      seat_status: ['AVAILABLE', 'OCCUPIED', 'RESERVED', 'LOCKED'],
      ranking_type: ['STUDY_TIME', 'STUDY_VOLUME', 'ATTENDANCE_STREAK'],
    };

    return {
      success: true,
      data: type ? { [type]: codes[type] ?? [] } : codes,
      meta: {},
    };
  }
}
