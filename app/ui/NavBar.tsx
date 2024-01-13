'use client'
import { Navbar } from "flowbite-react";
import Image from 'next/image'
import { CustomConnectButton } from './CustomConnectButton'

export const NavBar = () => {
    return (
        <Navbar fluid={true} rounded={true}>
            <Navbar.Brand href="https://flowbite.com/">
            <Image
      src="/gho_logo.png"
      width={80}
      height={0}
      alt="GHOption logo parseb"
    />

            </Navbar.Brand>
            <Navbar.Toggle />
            <Navbar.Collapse>
                <Navbar.Link href="/take" active={true}>
                    give
                </Navbar.Link>
                <Navbar.Link href="/offer">take</Navbar.Link>
                <Navbar.Link href="/bag">bag</Navbar.Link>
            </Navbar.Collapse>
            <CustomConnectButton />
        </Navbar>
    );
};
