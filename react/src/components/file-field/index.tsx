import * as React from 'react';
import { TextField } from '@material-ui/core';
import { PublishRounded } from '@material-ui/icons';
import './styles.scss';

interface FileFieldProps {
  label: string | null;
  required: boolean | false;
  setValue: (value: any) => void;
}

const FileFieldComponent: React.FC<FileFieldProps> = ({
  label,
  required,
  setValue,
}) => {
  const [fileName, setFileName] = React.useState('');

  return (
    <div className='lg-file-field'>
      <TextField
        className='lg-file-field--text-hidden'
        type='file'
        variant='outlined'
        onChange={(e: any) => {
          if (e.target?.files?.length) {
            const file = e.target.files[0];
            setFileName(String(file.name));
            setValue(file);
          }
        }}
      />

      <TextField
        value={fileName}
        aria-describedby='file'
        className='lg-file-field--text'
        variant='outlined'
        label={label}
        required={required}
        onChange={(e: any) => {
          if (e.target?.files?.length) {
            const file = e.target.files[0];
            setFileName(String(file.name));
            setValue(file);
          }
        }}
        inputProps={{
          className: 'lg-file-field--input',
        }}
        InputProps={{
          className: 'lg-file-field--outlined',
          classes: {
            notchedOutline: 'lg-file-field--notched',
          },
          endAdornment: <PublishRounded />,
        }}
        InputLabelProps={{
          className: 'lg-file-field--label',
        }}
      />
    </div>
  );
};

export default FileFieldComponent;
