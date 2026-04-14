import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ParentController } from './parent.controller';
import { ParentService } from './parent.service';

@Module({
  imports: [JwtModule.register({})],
  controllers: [ParentController],
  providers: [ParentService],
})
export class ParentModule {}
