import React from 'react';
import { 
  CheckCircleIcon, 
  XCircleIcon, 
  ExclaimationCircleIcon as ExclaimationCircleIcon, 
  InformationCircleIcon 
} from '@heroicons/react/24/outline';

export interface IconProps extends React.SVGProps<SVGSVGElement> {
  className?: string;
}

export const CheckIcon = ({ className = 'h-5 w-5', ...props }: IconProps) => (
  <CheckCircleIcon className={className} {...props} />
);

CheckIcon.displayName = 'CheckIcon';

export const ErrorIcon = ({ className = 'h-5 w-5', ...props }: IconProps) => (
  <XCircleIcon className={className} {...props} />
);

ErrorIcon.displayName = 'ErrorIcon';

export const WarningIcon = ({ className = 'h-5 w-5', ...props }: IconProps) => (
  <ExclaimationCircleIcon className={className} {...props} />
);

WarningIcon.displayName = 'WarningIcon';

export const InfoIcon = ({ className = 'h-5 w-5', ...props }: IconProps) => (
  <InformationCircleIcon className={className} {...props} />
);

InfoIcon.displayName = 'InfoIcon';

// Re-export commonly used heroicons
export { 
  CheckCircleIcon, 
  XCircleIcon, 
  ExclaimationCircleIcon, 
  InformationCircleIcon 
} from '@heroicons/react/24/outline';
