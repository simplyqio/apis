import React from 'react';
import styles from './styles.module.css';

export default function StepsContainer({children}): JSX.Element {
  return (
    <div className={styles.stepsContainer}>
      {children}
    </div>
  );
}
