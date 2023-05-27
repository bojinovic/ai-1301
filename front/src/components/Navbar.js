import "../style/css/Navbar.css";

const Navbar = () => {
  return (
    <div className="Navbar">
      <div className="Logo">
        <h2>
          <b>AI:1301</b>
        </h2>
      </div>
      <div className="PageList">
        <div className="Entry">
          <h3>About</h3>
        </div>
        <div className="Entry">
          <h3>Contact</h3>
        </div>
      </div>
    </div>
  );
};

export default Navbar;
