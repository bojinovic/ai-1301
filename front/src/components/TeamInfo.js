import "../style/css/TeamInfo.css";
const PLAYERS = [
  {
    name: "Milos Milutinovic",
    speed: 100,
    stamina: 43,
    skill: 40,
  },
  {
    name: "Milos Milutinovic",
    speed: 190,
    stamina: 43,
    skill: 40,
  },
  {
    name: "Marko Milutinovic",
    speed: 100,
    stamina: 43,
    skill: 30,
  },
  {
    name: "Milos Joksimovic",
    speed: 100,
    stamina: 23,
    skill: 40,
  },
  {
    name: "Dragan Petrovic",
    speed: 100,
    stamina: 43,
    skill: 40,
  },
];

const TeamInfo = () => {
  return (
    <div className="TeamInfo">
      <table className="Lignup">
        <tr className="Head">
          <th className="Name">Name</th>
          <th>Speed</th>
          <th>Stamina</th>
          <th>Skill</th>
        </tr>
        {PLAYERS.map((e) => {
          return (
            <tr>
              <td className="Name">{e.name}</td>
              <td>{e.speed}</td>
              <td>{e.stamina}</td>
              <td>{e.skill}</td>
            </tr>
          );
        })}
      </table>
    </div>
  );
};

export default TeamInfo;
