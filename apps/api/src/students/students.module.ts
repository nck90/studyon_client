import { Module } from '@nestjs/common';
import { CharactersModule } from '@/characters/characters.module';
import { EventsModule } from '@/events/events.module';
import { MediaModule } from '@/media/media.module';
import { PointsModule } from '@/points/points.module';
import { StudentsController } from './students.controller';
import { StudentsService } from './students.service';

@Module({
  imports: [EventsModule, MediaModule, PointsModule, CharactersModule],
  controllers: [StudentsController],
  providers: [StudentsService],
  exports: [StudentsService],
})
export class StudentsModule {}
