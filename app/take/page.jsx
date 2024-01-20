import React from 'react';
import {
    Button,
    Label,
    RangeSlider,
    Select,
    Textarea,
    TextInput,
    Dropdown,
    DropdownItem,
    Datepicker,
    RangeSliderProps,
    h1
} from 'flowbite-react';
import {  Table, TabItem, TableCell, TableHead, TableRow, TableHeadCell, TableBody } from 'flowbite-react';

const TakePage = () => {
    const assets = [
        { asset: 'arETH', duration: '12 days', cost: '$243' },
        { asset: 'aWETH', duration: '270 dats', cost: '$1200' },
        { asset: 'aMKR', duration: '2 days', cost: '$32' },
    ];

    return (
        <div className="container" style={{ height: '100vh' }}>
                                 <h1 style={{margin:'0 auto',display:'flex', justifyContent:'center'}}>Offers</h1>

        <div className='container' style={{ display: 'flex', justifyContent: 'center'}}>
            <br />
            <hr />

            <br />
            <Dropdown id="asset-selector" label={"aToken"} >
            <DropdownItem value="wrETH" key={1}> 
                   aRETH
                   </DropdownItem>
                   <DropdownItem value="aWETH" key={2}> 
                   aWETH
                   </DropdownItem>

                   <DropdownItem value="aMKR" key={3}> 
                   aMKR
                   </DropdownItem>
                    </Dropdown>
            <br />
            <div className="sliders">
            <div className="flex max-w-md flex-col gap-4">
      <div>
        <div className="mb-1 block">
          <Label htmlFor="default-range" value="Max cost" />
        </div>
        <RangeSlider id="default-range" />
      </div>
      </div>
      <div className="flex max-w-md flex-col gap-4">
      <div>
        <div className="mb-1 block">
          <Label htmlFor="default-range" value="Duration" />
        </div>
        <RangeSlider id="default-range" />
      </div>
      </div>
            </div>
<br/>
            <Table className="table">
                <TableHead>
                        <TableHeadCell>Asset</TableHeadCell>
                        <TableHeadCell>Duration</TableHeadCell>
                        <TableHeadCell>Cost</TableHeadCell>
                </TableHead>
                <TableBody>
                    {assets.map((asset, index) => (
                        <TableRow key={index}>
                            <TableCell>{asset.asset}</TableCell>
                            <TableCell>{asset.duration}</TableCell>
                            <TableCell>{asset.cost}</TableCell>
                        </TableRow>
                    ))}
                </TableBody>
                
            </Table>
            <Button>Mint Option</Button>


        </div>
        
        </div>

    );
};

export default TakePage;
