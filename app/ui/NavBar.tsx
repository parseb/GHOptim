'use client'
import { Navbar } from "flowbite-react";
import Image from 'next/image'
import { CustomConnectButton } from './CustomConnectButton'
import { usePathname } from "next/navigation";


export const NavBar = () => {
    let pathname = usePathname();
    return (
        <Navbar fluid={true} rounded={false}>
            <Navbar.Brand href="/">
                <Image
                    src="/gho_logo.png"
                    width={80}
                    height={0}
                    alt="GHOption logo parseb"
                />
            </Navbar.Brand>
            <Navbar.Toggle />
            <Navbar.Collapse color="black">
                <Navbar.Link href="/take" active={pathname == '/take'}>
                    take
                </Navbar.Link>
                <Navbar.Link href="/give" active={pathname == '/give'}>give</Navbar.Link>
                <Navbar.Link href="/bag" active={pathname == '/bag'}>bag</Navbar.Link>
            </Navbar.Collapse>
            <CustomConnectButton />
        </Navbar>
    );
};
