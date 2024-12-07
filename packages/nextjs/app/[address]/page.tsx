import React from "react";
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts";
import { Button } from "~~/~/components/ui/button";
import { ChartConfig, ChartContainer, ChartTooltip, ChartTooltipContent } from "~~/~/components/ui/chart";

async function page({ params }: { params: Promise<{ address: string }> }) {
  const chartData = [
    { month: "January", desktop: 186, mobile: 80 },
    { month: "February", desktop: 305, mobile: 200 },
    { month: "March", desktop: 237, mobile: 120 },
    { month: "April", desktop: 73, mobile: 190 },
    { month: "May", desktop: 209, mobile: 130 },
    { month: "June", desktop: 214, mobile: 140 },
  ];

  const chartConfig = {
    desktop: {
      label: "Desktop",
      color: "hsl(var(--chart-1))",
    },
    mobile: {
      label: "Mobile",
      color: "hsl(var(--chart-2))",
    },
  } satisfies ChartConfig;

  const slug = (await params).address;
  return (
    <div className="flex flex-col gap-y-4 justify-center items-center p-10">
      <h1 className="text-4xl">This is the queston ??? </h1>
      {/* <ChartContainer config={chartConfig}>
        <AreaChart
          accessibilityLayer
          data={chartData}
          margin={{
            left: 12,
            right: 12,
          }}
        >
          <CartesianGrid vertical={false} />
          <XAxis
            dataKey="month"
            tickLine={false}
            axisLine={false}
            tickMargin={8}
            tickFormatter={value => value.slice(0, 3)}
          />
          <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="dot" />} />
          <Area
            dataKey="mobile"
            type="natural"
            fill="var(--color-mobile)"
            fillOpacity={0.4}
            stroke="var(--color-mobile)"
            stackId="a"
          />
          <Area
            dataKey="desktop"
            type="natural"
            fill="var(--color-desktop)"
            fillOpacity={0.4}
            stroke="var(--color-desktop)"
            stackId="a"
          />
        </AreaChart>
      </ChartContainer> */}

      <div className="flex gap-4">
        <button className="bg-white px-8 py-2 text-black rounded-md" type="button">
          <div className="text-lg">Yes</div>
          <span>$25</span>
        </button>
        <button className="bg-white px-8 py-2 text-black rounded-md" type="button">
          <div className="text-lg">No</div>
          <span>$25</span>
        </button>
      </div>
    </div>
  );
}

export default page;
