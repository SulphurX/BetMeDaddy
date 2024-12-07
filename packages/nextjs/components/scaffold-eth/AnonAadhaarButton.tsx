"use client";

import { useEffect } from "react";
import { LogInWithAnonAadhaar, useAnonAadhaar } from "@anon-aadhaar/react";

export const AnonAadhaarButton = () => {
  const [anonAadhaar] = useAnonAadhaar();

  useEffect(() => {
    console.log("Anon Aadhaar status:", anonAadhaar.status);
  }, [anonAadhaar]);

  return (
    <div className="flex items-center gap-3">
      <LogInWithAnonAadhaar nullifierSeed={1234} />
      {anonAadhaar.status === "logged-in" && <span className="text-sm font-normal text-green-500">✓ Verified</span>}
    </div>
  );
};
