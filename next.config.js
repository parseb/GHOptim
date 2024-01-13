/** @type {import('next').NextConfig} */
const nextConfig = {
    plugins: [
        require('flowbite/plugin')
    ],
    webpack: (config) => {
        config.resolve.fallback = { fs: false, net: false, tls: false };
        return config;
      }
}

module.exports = nextConfig
