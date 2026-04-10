/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      // Placeholder / dev images
      { protocol: "https", hostname: "picsum.photos", pathname: "/**" },
      // Cloudinary
      { protocol: "https", hostname: "res.cloudinary.com", pathname: "/**" },
      // Supabase Storage
      { protocol: "https", hostname: "*.supabase.co", pathname: "/storage/**" },
      // Uploadthing
      { protocol: "https", hostname: "utfs.io", pathname: "/**" },
      // AWS S3 / CloudFront
      { protocol: "https", hostname: "*.amazonaws.com", pathname: "/**" },
      { protocol: "https", hostname: "*.cloudfront.net", pathname: "/**" },
      // TryCloudflare (for development)
      { protocol: "https", hostname: "*.trycloudflare.com", pathname: "/**" },
      // Local development API
      { protocol: "http", hostname: "localhost", pathname: "/uploads/**" },
      { protocol: "http", hostname: "127.0.0.1", pathname: "/uploads/**" },
      { protocol: "http", hostname: "192.168.0.43", pathname: "/uploads/**" },
      {
        protocol: "https",
        hostname: "**",
        pathname: "/**",
      },
    ],
  },
  // Allow cross-origin HMR from local network IPs during development
  allowedDevOrigins: ["192.168.0.43"],
};

module.exports = nextConfig;
