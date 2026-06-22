import { join } from "node:path";
import type { NextConfig } from "next";

const outputFileTracingRoot =
  process.env.NEXT_OUTPUT_FILE_TRACING_ROOT ?? join(process.cwd(), "../..");

const API_URL =
  process.env.API_URL ??
  (process.env.NODE_ENV === "production"
    ? "https://studyon-server.hyphen.it.com"
    : "https://studyon-server.hyphen.it.com");

const nextConfig: NextConfig = {
  output: "standalone",
  outputFileTracingRoot,
  poweredByHeader: false,
  reactStrictMode: true,
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: `${API_URL}/api/:path*`,
      },
    ];
  },
};

export default nextConfig;
