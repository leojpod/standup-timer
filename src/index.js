import './main.css'
import { Elm } from './elm/Main.elm'
import registerServiceWorker from './registerServiceWorker'

const params = new URL(window.location).searchParams
const timeParam = params && params.get('time')
Elm.Main.init({ flags: timeParam || null })

registerServiceWorker()
