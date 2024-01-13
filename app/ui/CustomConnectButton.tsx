import { ConnectKitButton } from "connectkit";
import styled from "styled-components";

const StyledButton = styled.button`
  cursor: pointer;
  position: relative;
  display: inline-block;
  padding: 14px 24px;
  color: #ffffff;
  background: #2F592F;
  font-size: 12px;'
  font-weight: 600;
  transition: 200ms ease;
  &:hover {
    border-color: #0184BF;
  }
  &:active {
    border-color: #2F592F;
  }
`;



export const CustomConnectButton = () => {
  return (
    <ConnectKitButton.Custom>
      {({ isConnected, show, truncatedAddress, ensName }) => {
        return (
          <StyledButton onClick={show}>
            {isConnected ? ensName ?? truncatedAddress : "Connect 👉👈"}
          </StyledButton>
        );
      }}
    </ConnectKitButton.Custom>
  );
};