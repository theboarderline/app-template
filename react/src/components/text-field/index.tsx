import * as React from 'react';
import { TextField } from '@material-ui/core';
import './styles.scss';

interface TextFieldProps {
  value: string;
  onChange: (e: React.ChangeEvent<{ value: string }>) => void;
  id: string;
  helperText?: string;
  label?: string;
  type?: string;
  autoComplete?: string;
  shrinkLabel?: boolean;
  multiline?: boolean;
  maxRows?: number;
  handleSubmit?: any;
}


const TextFieldComponent: React.FC<TextFieldProps> = ({
  onChange,
  value,
  id,
  helperText,
  label,
  type = 'text',
  autoComplete = 'text',
  shrinkLabel,
  multiline,
  maxRows,
  handleSubmit,
}) => {
  return (
    <TextField
      className='lake-games--text'
      color='primary'
      inputProps={{ type, autoComplete }}
      InputProps={{
        className: 'lake-games--text-input',
        classes: {
          notchedOutline: 'lake-games--input-outline',
          focused: 'lake-games--input-focused',
          input: 'lake-games--input',
        },
      }}
      InputLabelProps={{
        shrink: shrinkLabel,
        className: 'lake-games--text-label',
        classes: {
          outlined: 'lake-games--text-label-outlined',
          focused: 'lake-games--label-focused',
        },
      }}
      id={id}
      fullWidth
      label={label}
      onChange={onChange}
      value={value}
      helperText={helperText}
      multiline
      maxRows={maxRows || 100}
      variant='outlined'
    />
  );
};

export default TextFieldComponent;
