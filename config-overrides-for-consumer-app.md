# Prompt para Arreglar el Error en Create React App (Consumer App Básica)

## Problema
Error al consumir el SDK en una CRA básica:
```
./node_modules/@emmanuelacostaiugo/react-inji-verify-sdk/dist/index.js 21181:30
Module parse failed: Unexpected token
```

## Solución para Create React App Básica

### Paso 1: Instalar react-app-rewired

```bash
npm install --save-dev react-app-rewired
```

### Paso 2: Crear config-overrides.js

En la raíz de tu consumer app (mismo nivel que `package.json`), crea el archivo:

```javascript
// config-overrides.js
module.exports = function override(config, env) {
  // Encontrar la regla de babel-loader
  const babelLoaderRule = config.module.rules.find(
    (rule) =>
      rule.oneOf &&
      rule.oneOf.find((oneOf) =>
        oneOf.test && oneOf.test.toString().includes('tsx|ts')
      )
  );

  if (babelLoaderRule && babelLoaderRule.oneOf) {
    babelLoaderRule.oneOf.forEach((rule) => {
      if (rule.test && rule.test.toString().includes('tsx|ts')) {
        // Excluir explícitamente el SDK del procesamiento
        rule.exclude = [
          /node_modules/,
          /node_modules\/@emmanuelacostaiugo\/react-inji-verify-sdk/,
        ];
      }
    });
  }

  return config;
};
```

### Paso 3: Actualizar package.json

Cambia los scripts en `package.json`:

```json
{
  "scripts": {
    "start": "react-app-rewired start",
    "build": "react-app-rewired build",
    "test": "react-app-rewired test"
  }
}
```

### Paso 4: Instalar el SDK

```bash
npm install @emmanuelacostaiugo/react-inji-verify-sdk@latest
```

### Paso 5: Importar el SDK

En tu componente (ej: `src/App.tsx`):

```typescript
// IMPORTANTE: Importar el CSS primero
import '@emmanuelacostaiugo/react-inji-verify-sdk/dist/styles.css';

// Luego los componentes
import { OpenID4VPVerification, QRCodeVerification } from '@emmanuelacostaiugo/react-inji-verify-sdk';

function App() {
  return (
    <div className="App">
      {/* Usa los componentes aquí */}
    </div>
  );
}

export default App;
```

## Alternativa sin react-app-rewired (más simple)

Si prefieres NO modificar la configuración, el problema probablemente es que el SDK tiene caracteres especiales o formato que CRA no puede procesar.

### Opción A: Verificar que excluye node_modules

Por defecto CRA YA excluye node_modules, pero puedes forzarlo en `tsconfig.json`:

```json
{
  "compilerOptions": {
    // ... tus opciones existentes
  },
  "exclude": [
    "node_modules",
    "**/node_modules/**"
  ]
}
```

### Opción B: Verificar el archivo del SDK

Abre este archivo en tu consumer app:
```
node_modules/@emmanuelacostaiugo/react-inji-verify-sdk/dist/index.js
```

- Debe empezar con `(function webpackUniversalModuleDefinition(root, factory) {`
- NO debe tener caracteres raros al inicio
- Debe ser texto legible JavaScript

Si el archivo se ve bien, el problema está en cómo CRA lo detecta.

## Solución Temporal (mientras se arregla el SDK)

Si el problema persiste, puedes usar el SDK de forma diferente:

### En src/index.ts del SDK (antes de publicarlo):

```typescript
// Asegúrate de que la exportación sea limpia
export { default as OpenID4VPVerification } from './components/openid4vp-verification/OpenID4VPVerification';
export { default as QRCodeVerification } from './components/qrcode-verification/QRCodeVerification';
```

### Verificar el encoding del build

El SDK debe generar UTF-8 sin BOM. Verifica en el webpack del SDK:

```javascript
// En inji-verify-sdk/webpack.config.js
module.exports = {
  // ... configuración existente
  output: {
    // ... configuración existente
    // Asegurar encoding correcto
    clean: true, // Limpiar output anterior
  },
};
```

## Pasos de Ejecución en Consumer App

1. **Instalar dependencias:**
   ```bash
   npm install
   ```

2. **Reiniciar el dev server:**
   ```bash
   npm start
   ```

3. **Si el error persiste, limpiar caché:**
   ```bash
   rm -rf node_modules/.cache
   npm start
   ```

## Verificación Final

El error "Module parse failed" debe desaparecer y poder importar:

```typescript
import { OpenID4VPVerification } from '@emmanuelacostaiugo/react-inji-verify-sdk';

// Y usar el componente
<OpenID4VPVerification
  // props aquí
/>
```

## Debugging

Si aún tienes problemas:

1. Abre `node_modules/@emmanuelacostaiugo/react-inji-verify-sdk/dist/index.js`
2. Ve a la línea 21181
3. Copia las líneas 21175-21190 y pégalas aquí para ver qué hay

El código debe verse como:
```javascript
this.paintType = IR[7];
this.tilingType = IR[8];
```

Si ves caracteres raros o binarios, el problema está en cómo se generó el bundle del SDK.

