import { SVGProps } from 'react';

declare module '@/components/icons' {
  export * from './common';
}

declare module '*.svg' {
  const content: React.FC<SVGProps<SVGElement>>;
  export default content;
}
