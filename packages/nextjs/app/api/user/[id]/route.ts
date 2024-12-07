import { NextRequest, NextResponse } from "next/server";
import { db } from "~~/lib/prisma";

// Write the api for getting a pod by id route /api/pods/[id]
export const GET = async (
  req: NextRequest,
  {
    params,
  }: {
    params: { id: string };
  },
): Promise<NextResponse> => {
  const { id } = params;
  const profile = await db.profile.findUnique({
    where: {
      id: id as string,
    },
    include: {
      user: true,
    },
  });
  return new NextResponse(JSON.stringify(profile));
};
