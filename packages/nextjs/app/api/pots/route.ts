import { NextRequest, NextResponse } from "next/server";

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export const GET = async (req: NextRequest): Promise<NextResponse> => {
  const body: BodyInit = JSON.stringify({ message: "Hello, World!" });
  return new NextResponse(body);
};
