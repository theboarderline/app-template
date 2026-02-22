import * as React from 'react';
import {Button, DialogTitle, Dialog, DialogContent} from '@material-ui/core';
import './styles.scss';

interface DialogProps {
    title: string | null;
    isOpen?: boolean;
    removeButton?: boolean;
    handleCloseHook?: any;
}

const DialogBox: React.FC<DialogProps> = ({title, isOpen, removeButton, handleCloseHook, children}) => {
    const [open, setOpen] = React.useState(isOpen || false);

    const handleClickOpen = () => {
        setOpen(true);
    };

    const handleClose = () => {
        setOpen(false);
        if (handleCloseHook)
          handleCloseHook()
    };

    return (
        <>
          {!removeButton ? (
            <Button
              className='dialog-box--btn'
              variant='outlined'
              color='primary'
              onClick={handleClickOpen}
              classes={{label: 'dialog-box--btn-label'}}
            >
                {title}
            </Button>
            ) : <div>{title}</div>}

            <Dialog
                onClose={handleClose}
                className='dialog-box'
                aria-labelledby='simple-dialog-title'
                open={open}
                fullWidth
            >
                <DialogTitle
                    disableTypography
                    className='dialog-box--title'
                    id='simple-dialog-title'
                >
                    {title}
                </DialogTitle>
                <DialogContent className='dialog-box--content'>
                    {children}
                    <br/>
                    <Button
                        className='dialog-box--btn'
                        variant='outlined'
                        color='primary'
                        onClick={handleClose}
                        classes={{label: 'dialog-box--btn-label'}}
                    >
                        Close
                    </Button>
                </DialogContent>
            </Dialog>
        </>
    );
};

export default DialogBox;
