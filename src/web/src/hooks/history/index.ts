import { useEffect } from 'react'
import { useHistory } from 'react-router-dom'

export const useRouteChangeHandler = () => {
  const history = useHistory()
  
  useEffect(() => {
    const stopListening = history?.listen((location, action) => {
      const pathname = location.pathname.trim()
      const shouldSet = pathname !== "/" && pathname !== "/home" && pathname !== "/login"
      if (shouldSet)
        localStorage.setItem('lastPath', pathname)
    })
    
    return () => {
      stopListening()
    }
  }, [history])
}
