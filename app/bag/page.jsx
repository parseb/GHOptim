// `app/dashboard/page.tsx` is the UI for the `/dashboard` URL
export default function Page() {
    const items = [
        { title: "Title 1" },
        { title: "Title 2" },
        { title: "Title 3" }
    ];

    return (
        <div className="center-container">
            <div className="dashboard">
                <div className="box"></div>
                <div className="box"></div>
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.map((item, index) => (
                            <tr key={index}>
                                <td>{item.title}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
