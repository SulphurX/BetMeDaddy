import { NextRequest, NextResponse } from "next/server";
import { randomUUID } from "crypto";
import { db } from "~~/lib/prisma";

export const POST = async (req: NextRequest): Promise<NextResponse> => {
  const data: {
    id?: string;
    wallet: string;
    isCompany: boolean;
    profile: {
      id?: string;
      image: string;
      github: string;
      linkedin: string;
      twitter: string;
      userId?: string;
    };
  } = await req.json();
  data.id = randomUUID();
  const { profile, ...userData } = data;
  const user = await db.user.create({ data: userData });
  profile.id = randomUUID();
  profile.userId = data.id;
  await db.profile.create({ data: profile });
  const response = { ...user, profile };
  return new NextResponse(JSON.stringify(response), {
    status: 201,
  });
};
