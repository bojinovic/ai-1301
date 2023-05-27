import Navbar from "./components/Navbar";

import "./style/css/App.css";

import Playout from "./pages/Playout";
const App = () => {
  return (
    <div className="App">
      <Navbar></Navbar>
      <Playout></Playout>
    </div>
  );
};

export default App;
