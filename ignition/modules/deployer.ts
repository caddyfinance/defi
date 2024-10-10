import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DeployerModule = buildModule("DeployerModule", (m) => {
  // Deploy USDT contract
//   const usdt = m.contract("USDT");
const usdt = "0x1D12E1bD5Cc44091834b54A4A82A6F6f2e36d789";
  // Deploy Lending contract
  const lending = m.contract("Lending");

  // Initialize Lending contract
  const initLending = m.call(lending, "initialize", [
    usdt,
    "0x82a064e98c5fa88bff67Bc27B755aC3c0E77EA0D",
    "30", // Default to 1 day in seconds
    "5", // Default to 5% rate
  ]);

  // Deploy YieldPool contract
  const yieldPool = m.contract("yieldpool");

  // Initialize YieldPool contract
  const initYieldPool = m.call(yieldPool, "initialize", [
    usdt,
    lending,
    lending,
  ]);
  console.log( "duration is 30 seconds and rate is 5%");

  return { lending, yieldPool};
});

export default DeployerModule;
