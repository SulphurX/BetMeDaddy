import { NextRequest, NextResponse } from "next/server";
import { randomUUID } from "crypto";
import { db } from "~~/lib/prisma";

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export const GET = async (req: NextRequest): Promise<NextResponse> => {
  const body: BodyInit = JSON.stringify({ message: "Hello, World!" });
  return new NextResponse(body);
};

export const POST = async (req: NextRequest): Promise<NextResponse> => {
  const data: {
    id: string;
    title: string;
    slug: string;
    deadline: string;
    description: string;
    token: string;
    rewardAmount: number;
    rewards: string[];
    skills: string[];
    type: string;
    requirements: string[];
    totalPaymentMade: number;
    totalWinnersSelected: number;
    isWinnerAnnounced: boolean;
    region: string;
    pocSocial: string;
    timeToComplete: string;
    winners: string[];
    sponsors: string[];
  } = await req.json();
  data.id = randomUUID();
  const response = await db.pods.create({ data });
  return new NextResponse(JSON.stringify(response), {
    status: 201,
  });
};
