"use client";

import type { NextPage } from "next";
import { Table, TableBody, TableCell, TableRow } from "~~/~/components/ui/table";

const Home: NextPage = () => {
  const invoices = [
    {
      id: 1,
      companyName: "Eth",
      issueName: "$250.00",
      paymentMethod: "Credit Card",
    },
    {
      id: 2,
      companyName: "Sol",
      issueName: "$150.00",
      paymentMethod: "PayPal",
    },
    {
      id: 3,
      companyName: "Nim",
      issueName: "$350.00",
      paymentMethod: "Bank Transfer",
    },
    {
      id: 4,
      companyName: "Coin",
      issueName: "$450.00",
      paymentMethod: "Credit Card",
    },
    {
      id: 5,
      companyName: "Socket",
      issueName: "$550.00",
      paymentMethod: "PayPal",
    },
    {
      id: 6,
      companyName: "Cursive",
      issueName: "$200.00",
      paymentMethod: "Bank Transfer",
    },
    {
      id: 7,
      companyName: "Ploygon",
      issueName: "$300.00",
      paymentMethod: "Credit Card",
    },
  ];

  return (
    <div className="mx-14 my-8">
      <Table className="max-w-[60vw]">
        {/* <TableCaption>A list of your recent invoices.</TableCaption> */}
        {/* <TableHeader>
          <TableRow>
            <TableHead className="w-[100px]">Invoice</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Method</TableHead>
            <TableHead className="text-right">Amount</TableHead>
          </TableRow>
        </TableHeader> */}
        <TableBody>
          {invoices.map(invoice => (
            <TableRow key={invoice.id} className="border-b border-b-white/45">
              <TableCell className=" py-4">{invoice.companyName}</TableCell>
              <TableCell className=" py-4">{invoice.paymentMethod}</TableCell>
              <TableCell className="text-right">{invoice.issueName}</TableCell>
            </TableRow>
          ))}
        </TableBody>
        {/* <TableFooter>
          <TableRow>
            <TableCell colSpan={3}>Total</TableCell>
            <TableCell className="text-right">$2,500.00</TableCell>
          </TableRow>
        </TableFooter> */}
      </Table>
    </div>
  );
};

export default Home;
