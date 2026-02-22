import React, { useRef, useState } from 'react';
import { Toast } from 'primereact/toast';
import { FileUpload } from 'primereact/fileupload';
import { ProgressBar } from 'primereact/progressbar';
import { Button } from 'primereact/button';
import { Tooltip } from 'primereact/tooltip';
import { Tag } from 'primereact/tag';

interface FileFieldProps {
  id?: string
  setFiles?: any
  callback?: any
}

const FileFieldComponent: React.FC<FileFieldProps> = ({ setFiles, callback }) => {
  const [totalSize, setTotalSize] = useState(0);
  const toast = useRef(null);
  const fileUploadRef = useRef(null);
  
  const onTemplateSelect = (e: any) => {
    setFiles(e?.files)
    let _totalSize = totalSize;
    e?.files?.forEach((file: any) => {
      _totalSize += file?.size;
    });

    setTotalSize(_totalSize);
  }
  
  const onTemplateRemove = (file: any, callback: any) => {
    setTotalSize(totalSize - file?.size);
    if (callback) callback();
  }

  const onTemplateClear = () => {
    setTotalSize(0);
  }

  const headerTemplate = (options: any) => {
    const { className, chooseButton, cancelButton } = options;
    const value = totalSize/10000;
    // @ts-ignore
    const formatedValue = fileUploadRef?.current?.formatSize(totalSize) ?? '0 B';

    return (
      <div className={className} style={{backgroundColor: 'transparent', display: 'flex', alignItems: 'center'}}>
        {chooseButton}
        {cancelButton}
        <ProgressBar value={value} displayValueTemplate={() => `${formatedValue} / 1 MB`} style={{
          width: '300px',
          height: '20px',
          marginLeft: 'auto'
        }}/>
      </div>
    );
  }

  const itemTemplate = (file: any, props: any) => {
    return (
      <div className="flex align-items-center flex-wrap">
        <div className="flex align-items-center" style={{width: '50%'}}>
          <img alt={file.name} role="presentation" src={file?.objectURL} width={100} />
          <span className="flex flex-column text-left ml-3">
            {file?.name}
            <small>{new Date().toLocaleDateString()}</small>
          </span>
        </div>
        <Tag value={props.formatSize} severity="warning" className="px-3 py-2" />
        <Button type="button" icon="pi pi-times" className="p-button-outlined p-button-rounded p-button-danger ml-auto" onClick={() => onTemplateRemove(file, props.onRemove)} />
      </div>
    )
  }

  const emptyTemplate = () => {
    return (
      <div className="flex align-items-center flex-column">
        <i className="pi pi-image mt-3 p-5" style={{
          'fontSize': '5em',
          borderRadius: '50%',
          backgroundColor: 'var(--surface-b)',
          color: 'var(--surface-d)'
        }}/>
        <span style={{'fontSize': '1.2em', color: 'var(--text-color-secondary)'}} className="my-5">Drag and Drop Image Here</span>
      </div>
    )
  }

  const chooseOptions = {icon: 'pi pi-fw pi-images', iconOnly: true, className: 'custom-choose-btn p-button-rounded p-button-outlined'};
  const cancelOptions = {icon: 'pi pi-fw pi-times', iconOnly: true, className: 'custom-cancel-btn p-button-danger p-button-rounded p-button-outlined'};
  
  return (
    <div>
      <Toast ref={toast}/>
      
      <Tooltip target=".custom-choose-btn" content="Choose" position="bottom" />
      <Tooltip target=".custom-cancel-btn" content="Clear" position="bottom" />
      
      <div className="card">
        <FileUpload ref={fileUploadRef} name="uploads[]" multiple accept="image/*" maxFileSize={10000000}
          onSelect={onTemplateSelect} onError={onTemplateClear} onClear={onTemplateClear}
          headerTemplate={headerTemplate} itemTemplate={itemTemplate} emptyTemplate={emptyTemplate}
          chooseOptions={chooseOptions} cancelOptions={cancelOptions} />
      </div>
    </div>
  )
}

export default FileFieldComponent