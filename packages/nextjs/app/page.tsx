"use client";

// import Link from "next/link";
import Link from "next/link";
import type { NextPage } from "next";

// import { useAccount } from "wagmi";
// import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
// import { Address } from "~~/components/scaffold-eth";

const Home: NextPage = () => {
  // const { address: connectedAddress } = useAccount();

  const data = [
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
    {
      question: "This is a question ???",
      byAddress: "0x1244...234234",
    },
  ];

  return (
    <div className="flex p-10 justify-items-center ">
      <div className="grid grid-cols-5 gap-4 items-center">
        {data.map((items, index) => {
          return (
            <Link
              key={index}
              href={"/0x12345"}
              className="border border-white/25 rounded-lg p-6 hover:shadow-md transition-all"
            >
              <h2 className="text-2xl">{items.question}</h2>
              <span className="text-sm text-white/50">by {items.byAddress}</span>
            </Link>
          );
        })}
      </div>
    </div>
  );
};

export default Home;
