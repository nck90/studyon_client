import { join } from "node:path";
import type { NextConfig } from "next";

const outputFileTracingRoot =
  process.env.NEXT_OUTPUT_FILE_TRACING_ROOT ?? join(process.cwd(), "../..");

const nextConfig: NextConfig = {
  output: "standalone",
  outputFileTracingRoot,
  async rewrites() {
    const apiUrl =
      process.env.API_URL ?? "https://studyon-server.hyphen.it.com";
    return [
      {
        source: "/api/:path*",
        destination: `${apiUrl}/api/:path*`,
      },
    ];
  },
};

export default nextConfig;
