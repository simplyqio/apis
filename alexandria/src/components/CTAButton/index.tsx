import React from 'react';
import styles from './styles.module.css';

export default function CTAButton({href, children}): JSX.Element {
  return (
    <a href={href} className={styles.ctaButton}>
      {children}
    </a>
  );
}
