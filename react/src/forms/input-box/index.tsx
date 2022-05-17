import * as React from 'react'
import { Button } from '@material-ui/core'
import { Message, Loader, TextField } from '../../components'
import './styles.scss'

const InputBox: React.FC = () => {
  const [input, setInput] = React.useState('')
  const [msg, setMsg] = React.useState('')
  const [error, setError] = React.useState('')
  const [loading, setLoading] = React.useState(false)

  const handleSubmit = () => {
    setLoading(true)
    console.log('Handling submit for input form')
  }

  return (
    <>
      <Loader loading={loading} />
      <Message severity={'error'} message={error} />
      <Message severity='success' message={msg} />
      <br />
      <TextField
        value={input}
        id='input'
        label='Payout Input'
        autoComplete='input'
        multiline
        onChange={(e) => setInput(e.target.value)}
        handleSubmit={handleSubmit}
      />

      <Button variant='outlined' color='primary' onClick={handleSubmit}>
        <>Submit</>
      </Button>
    </>
  )
}

export default InputBox
