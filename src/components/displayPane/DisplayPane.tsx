import { useWeb3React } from "@web3-react/core";
import { Divider } from "antd";
import { useWindowWidthAndHeight } from "hooks";


import { VaultList } from "./components";
import AcornCard from "./components/AcornCard";
import AcornStats from "./components/AcornStats";
import AcornInfo from "./components/AcornInfo";

const styles = {
  container: {
    background: "##000509)",
    width: "100%",
    minWidth: "330px",
    maxWidth: "1000px",
    margin: "auto",
    textAlign: "center",
    padding: "0px 0",
    borderRadius: "10px",
    marginTop: "0px",
    boxShadow: "0px 12px 18px -6px rgba(0, 0, 0, 0.3)"
  },
  title: {
    color: "#ffffff",
    fontWeight: 600,
    fontFamily: "'Roboto', sans-serif",
    fontSize: "32px",
    marginBottom: "10px"
  },
  content: {
    width: "87%",
    margin: "auto",
    fontSize: "17px",
    marginTop: "0px",
    color: "#ffffff"
  },
  vaultcontent: {
    width: "95%",
    margin: "auto",
    fontSize: "18px",
    color: "#ffffff"
  },
  action: {
    background: "##000509)",
    width: "100%",
    minWidth: "330px",
    maxWidth: "900px",
    textAlign: "center",
    margin: "auto",
    padding: "30px 0",
    borderRadius: "10px",
    boxShadow: "0px 12px 18px -6px rgba(0, 0, 0, 0.3)"
  }
} as const;

const DisplayPane: React.FC = () => {
  const { isActive, chainId } = useWeb3React();
  const { isMobile } = useWindowWidthAndHeight();

  return (
    <div style={styles.container}>
      <div style={styles.content}>
        {!isActive && (
          <>
            <AcornInfo />
            <AcornStats />
          </>
        )}
        <div style={styles.vaultcontent}>
        {isActive && <AcornCard />}
        <VaultList key={chainId} />
        </div>
        {isActive && (
          <>
            <Divider />
            <div style={styles.action}>
              {!isMobile && <Divider type="vertical" style={{ fontSize: "120px !important" }} />}
            </div>
          </>
        )}
      </div>
    </div>
  );
};


export default DisplayPane;