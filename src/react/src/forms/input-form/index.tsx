import * as React from 'react'
import { Button } from '@material-ui/core'
import { Message, Loader, TextField } from '../../components'
import calculatePayout from '../../api'
import './styles.scss'

const InputForm: React.FC = () => {
  const [players, setPlayers] = React.useState('')
  const [result, setResult] = React.useState([])
  const [msg, setMsg] = React.useState('')
  const [error, setError] = React.useState('')
  const [loading, setLoading] = React.useState(false)

  const handleSubmit = () => {
    setLoading(true)
    calculatePayout(players).then((res) => {
      setLoading(false)
      if (res?.status === 200) {
        setMsg('Successfully queried payout API')
        setError('')
        setResult(res.data.split(/\r?\n/))
      } else {
        setError('Error querying payout API')
        setMsg('')
      }
    })
  }

  return (
    <>
      <h2>Expects input in following the form: </h2>
      <h3>Player1 X</h3>
      <h3>Player2 -X</h3>
      <br />
      <TextField
        value={players}
        id='players'
        label='Payout Input'
        autoComplete='players'
        onChange={(e) => setPlayers(e.target.value)}
        handleSubmit={handleSubmit}
      />

      <br />
      <Button variant='outlined' color='primary' onClick={handleSubmit}>
        <>Submit</>
      </Button>

      <br />
      <Loader loading={loading} />
      <br />
      <Message severity={'error'} message={error} />
      <Message severity='success' message={msg} />

      <br />

      {result.length ? (
        <>
          {result?.map((item: string) => (
            <h3>{item}</h3>
          ))}
        </>
      ) : null}
    </>
  )
}

export default InputForm
