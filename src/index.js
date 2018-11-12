import './main.css'
import { Main } from './elm/Main.elm'
import registerServiceWorker from './registerServiceWorker'

const params = (new URL(window.location)).searchParams
const timeParam = params && params.get('time')
Main.embed(document.getElementById('root'), timeParam || null)

registerServiceWorker()
