module.exports = {
  presets: [
    [
      "@babel/preset-env",
      {
        targets: {
          browsers: [">0.2%", "not dead", "not op_mini all"],
          node: "12" // Agrega soporte para Node 12+ (incluye 16)
        },
        modules: "auto", // Cambia de false a "auto" para transpilar a CommonJS
      },
    ],
    "@babel/preset-typescript",
    "@babel/preset-react",
  ],
};
