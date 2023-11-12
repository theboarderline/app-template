import * as React from 'react';
import './styles.scss';
import { Alert } from '@material-ui/lab';

interface MessageProps {
  label?: string
  message?: string
  severity?: 'success' | 'error' | 'info' | 'warning'
}

const Message: React.FC<MessageProps> = ({ message, severity = 'info', label }) => {
  let id = 'message-' + severity
  if (label) id = `${id}-${label}`
  
  return message ? (
    <div id={id}>
      <Alert
        className='lg-message'
        severity={severity}
        classes={{
          message: 'lg-message--text',
        }}
      >
        {message}
      </Alert>
    </div>
  ) : null;
};

export default Message;
