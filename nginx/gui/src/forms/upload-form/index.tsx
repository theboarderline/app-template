import * as React from 'react';
import { Button } from '@material-ui/core';
import { Message, Loader, FileField } from '../../components';
import './styles.scss';
import { uploadFile } from '../../api';

const UploadForm: React.FC = () => {

  const [error, setError] = React.useState('');
  const [loading, setLoading] = React.useState(false);
  const [msg, setMsg] = React.useState('');
  const [file, setFile] = React.useState<File>();

  const handleSubmit = () => {
    setLoading(true);
    if (!file) setError('Please select video file to upload');
    else {
      setError('');
      uploadFile(file).then((res: any) => {
        if (res?.status === 201) {
          setMsg('Successfully posted video');
          setLoading(false);
        }
      });
    }
  };


  return (
    <div className="cgs-video-form">
      <FileField label="Upload File" required setValue={setFile} />
      <Message
        severity={error ? 'error' : 'success'}
        message={error || msg}
      />

      <Loader loading={loading} />
      <Button
        variant="outlined"
        color="primary"
        onClick={handleSubmit}
        className="cgs-video-form--btn"
        classes={{
          label: 'cgs-video-form--btn-label'
        }}
      >
        Submit
      </Button>
    </div>
  );
};

export default UploadForm;
