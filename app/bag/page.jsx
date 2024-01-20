import { Button, Table, TabItem, TableCell, TableHead, TableRow, TableHeadCell, TableBody } from 'flowbite-react';

export default function Page() {
    const items = [
        { title: "Title 1" },
        { title: "Title 2" },
        { title: "Title 3" }
    ];

    return (
        <div className='container' style={{ height: '100vh' }}>
            <div className="dashboard">
                <div className="box"></div>
                <div className="box"></div>
                <Table>
                    <TableHead>
                        <TableHeadCell>Asset</TableHeadCell>
                        <TableHeadCell>Amount</TableHeadCell>
                        <TableHeadCell>Order</TableHeadCell>
                        <TableHeadCell>Expires in</TableHeadCell>
                        <TableHeadCell>P/L</TableHeadCell>
                        <TableHeadCell>Cost</TableHeadCell>
                        <TableHeadCell>Exe.Price</TableHeadCell>
                        <TableHeadCell></TableHeadCell>

                    </TableHead>
                    <TableBody>
                        <TableRow>
                            <TableCell>arETH</TableCell>
                            <TableCell>1</TableCell>
                            <TableCell>Buy</TableCell>
                            <TableCell>3 days</TableCell>
                            <TableCell>+106</TableCell>
                            <TableCell>226</TableCell>
                            <TableCell>2578</TableCell>

                            <TableCell>
                                <Button color="green">Early Close</Button>
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell>aWETH</TableCell>
                            <TableCell>3</TableCell>
                            <TableCell>Sell</TableCell>
                            <TableCell>1 days</TableCell>
                            <TableCell>-26</TableCell>
                            <TableCell>16</TableCell>
                            <TableCell>2518</TableCell>
                            <TableCell>
                                <Button color="green"> Early Close</Button>
                            </TableCell>
                        </TableRow>
                        <TableRow>
                            <TableCell>aMKR</TableCell>
                            <TableCell>47</TableCell>
                            <TableCell>Buy</TableCell>
                            <TableCell>124 days</TableCell>
                            <TableCell>+106</TableCell>
                            <TableCell>226</TableCell>
                            <TableCell>1020</TableCell>
                            <TableCell>
                                <Button color="red"> Liquidate</Button>
                            </TableCell>
                        </TableRow>
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
