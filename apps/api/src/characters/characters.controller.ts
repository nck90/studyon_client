import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ItemCategory, UserRole } from '@prisma/client';
import { CurrentUser } from '@/common/decorators/current-user.decorator';
import { Roles } from '@/common/decorators/roles.decorator';
import { JwtPayload } from '@/auth/types/jwt-payload.type';
import { CharactersService } from './characters.service';

@ApiTags('characters')
@ApiBearerAuth()
@Controller({ version: '1' })
export class CharactersController {
  constructor(private readonly charactersService: CharactersService) {}

  @Roles(UserRole.STUDENT)
  @Get('student/character')
  getMyCharacter(@CurrentUser() user: JwtPayload) {
    return this.charactersService.getMyCharacter(user.studentId!);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/character/shop')
  getShop(
    @CurrentUser() user: JwtPayload,
    @Query('category') category?: ItemCategory,
  ) {
    return this.charactersService.getShop(user.studentId!, category);
  }

  @Roles(UserRole.STUDENT)
  @Get('student/character/items')
  getOwnedItems(@CurrentUser() user: JwtPayload) {
    return this.charactersService.getOwnedItems(user.studentId!);
  }

  @Roles(UserRole.STUDENT)
  @Post('student/character/buy/:itemId')
  buyItem(@CurrentUser() user: JwtPayload, @Param('itemId') itemId: string) {
    return this.charactersService.buyItem(user.studentId!, itemId);
  }

  @Roles(UserRole.STUDENT)
  @Post('student/character/equip')
  equip(
    @CurrentUser() user: JwtPayload,
    @Body()
    body: {
      hatItemId?: string | null;
      glassesItemId?: string | null;
      outfitItemId?: string | null;
      bgItemId?: string | null;
      expressionItemId?: string | null;
    },
  ) {
    return this.charactersService.equip(user.studentId!, body);
  }
}
