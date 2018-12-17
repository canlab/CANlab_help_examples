
<map version="0.9.0">
    <node TEXT="CANlab [objects](https://canlab.github.io)" FOLDED="false" POSITION="right" ID="5c077388b668d8180faa2a23" X_COGGLE_POSX="1" X_COGGLE_POSY="-39">
        <edge COLOR="#9ed56b"/>
        <font NAME="Helvetica" SIZE="17"/>
        <node TEXT="@fmridisplay" FOLDED="false" POSITION="left" ID="927a7087fccd2359b239830bd51b93d5">
            <edge COLOR="#ebd95f"/>
            <font NAME="Helvetica" SIZE="15"/>
        </node>
        <node TEXT="@image_vector" FOLDED="false" POSITION="right" ID="b76e32588e837d895b0619cb1b57fbf6">
            <edge COLOR="#67d7c4"/>
            <font NAME="Helvetica" SIZE="15"/>
            <node TEXT="@fmri_data" FOLDED="false" POSITION="right" ID="16d3807500e23b2c58fb90ce55b01848">
                <edge COLOR="#66d4c0"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="@statistic_image" FOLDED="false" POSITION="right" ID="57719876a9703d1a6ccce43f178b9a9e">
                <edge COLOR="#988ee3"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
            <node TEXT="@atlas" FOLDED="false" POSITION="right" ID="aefd2a745a64e72b597a711dbd420f05">
                <edge COLOR="#e096e9"/>
                <font NAME="Helvetica" SIZE="13"/>
            </node>
        </node>
        <node TEXT="@region" FOLDED="false" POSITION="left" ID="7bc27bb985d54220ad4f8ce90f624ec0">
            <edge COLOR="#efa670"/>
            <font NAME="Helvetica" SIZE="15"/>
        </node>
        <node TEXT="@predictive_model" FOLDED="false" POSITION="right" ID="5666167dfc5fb6c92a31e5d635a83783">
            <edge COLOR="#9ed56b"/>
            <font NAME="Helvetica" SIZE="15"/>
        </node>
        <node TEXT="@canlab_dataset" FOLDED="false" POSITION="right" ID="bb5f9e81a7e41a5dd3858196a14f1aa5">
            <edge COLOR="#7aa3e5"/>
            <font NAME="Helvetica" SIZE="15"/>
        </node>
    </node>
    <x-coggle-rootnode TEXT="**Object types**" FOLDED="false" POSITION="right" ID="cfce2b41ccaf1bd21134840672933c9b" X_COGGLE_POSX="7" X_COGGLE_POSY="-181">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="17"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="**Do a t-test on a set of images**" FOLDED="false" POSITION="right" ID="83825e9d481b733a5062ffbcab046e66" X_COGGLE_POSX="-129" X_COGGLE_POSY="160">
        <edge COLOR="#b4b4b4"/>
        <font NAME="Helvetica" SIZE="17"/>
    </x-coggle-rootnode>
    <x-coggle-rootnode TEXT="fmri_data" FOLDED="false" POSITION="right" ID="30a97e459f164a6c31fc83f5a76b2bf0" X_COGGLE_POSX="-214" X_COGGLE_POSY="250">
        <edge COLOR="#67d7c4"/>
        <font NAME="Helvetica" SIZE="15"/>
        <node TEXT="ttest()" FOLDED="false" POSITION="right" ID="8fa67ebbf42bfcb2b145c07ae8dca624">
            <edge COLOR="#67d7c4"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="statistic_image" FOLDED="false" POSITION="right" ID="cfa728d721fb5280df60fec82862ec11">
                <edge COLOR="#988ee3"/>
                <font NAME="Helvetica" SIZE="17"/>
                <node TEXT="threshold()" FOLDED="false" POSITION="right" ID="2ef793aa01cabf92819b892ce7bd8ee0">
                    <edge COLOR="#958ce1"/>
                    <font NAME="Helvetica" SIZE="17"/>
                    <node TEXT="orthviews()  ![orthviews](https://coggle-images.s3.amazonaws.com/5c077388b668d806fbaa2a1f-03ff7e51-ed22-48fb-9c8d-e1ce1c44af65.png 100x100)" FOLDED="false" POSITION="right" ID="b4e2a84c304ddabf50619b3a2f0e167d">
                        <edge COLOR="#958de2"/>
                        <font NAME="Helvetica" SIZE="15"/>
                    </node>
                    <node TEXT="montage() ![montage](https://coggle-images.s3.amazonaws.com/5c077388b668d806fbaa2a1f-c198c746-0f3a-451d-971d-4d929b9fffbe.png 300x70) " FOLDED="false" POSITION="right" ID="bd4694fd8177e33121248bf30b073a60">
                        <edge COLOR="#8f87e0"/>
                        <font NAME="Helvetica" SIZE="17"/>
                    </node>
                    <node TEXT="region()" FOLDED="false" POSITION="right" ID="fbb914d8720e6942ae3257996627d6df">
                        <edge COLOR="#968fe0"/>
                        <font NAME="Helvetica" SIZE="15"/>
                        <node TEXT="region" FOLDED="false" POSITION="right" ID="87128ebfc7009a97eee3d15876cb3f4f">
                            <edge COLOR="#efa670"/>
                            <font NAME="Helvetica" SIZE="17"/>
                            <node TEXT="montage()" FOLDED="false" POSITION="right" ID="516a19aff6d0d159bc7524639158a2c2">
                                <edge COLOR="#efab7c"/>
                                <font NAME="Helvetica" SIZE="17"/>
                                <node TEXT="fmridisplay" FOLDED="false" POSITION="right" ID="068fe5496a699d1cab6a01e6ba3ba7e6">
                                    <edge COLOR="#ebd95f"/>
                                    <font NAME="Helvetica" SIZE="17"/>
                                </node>
                            </node>
                            <node TEXT="table ![table](https://coggle-images.s3.amazonaws.com/5c077388b668d806fbaa2a1f-e36c8be2-6058-4e46-aa9f-334750c6e58a.png 300x65) " FOLDED="false" POSITION="right" ID="fd799377221743d186720df4107e8080">
                                <edge COLOR="#eea979"/>
                                <font NAME="Helvetica" SIZE="17"/>
                            </node>
                        </node>
                    </node>
                </node>
            </node>
        </node>
        <node TEXT="plot() ![plot](https://coggle-images.s3.amazonaws.com/5c077388b668d806fbaa2a1f-bccdc47e-48d8-49b9-959a-18ec4c4aa144.png 300x113) " FOLDED="false" POSITION="right" ID="2c279b7a92bd65873933df2701feb62d">
            <edge COLOR="#63d7c1"/>
            <font NAME="Helvetica" SIZE="13"/>
            <node TEXT="region" FOLDED="false" POSITION="right" ID="87128ebfc7009a97eee3d15876cb3f4f">
                <edge COLOR="#efa670"/>
                <font NAME="Helvetica" SIZE="17"/>
                <node TEXT="montage()" FOLDED="false" POSITION="right" ID="516a19aff6d0d159bc7524639158a2c2">
                    <edge COLOR="#efab7c"/>
                    <font NAME="Helvetica" SIZE="17"/>
                    <node TEXT="fmridisplay" FOLDED="false" POSITION="right" ID="068fe5496a699d1cab6a01e6ba3ba7e6">
                        <edge COLOR="#ebd95f"/>
                        <font NAME="Helvetica" SIZE="17"/>
                    </node>
                </node>
                <node TEXT="table ![table](https://coggle-images.s3.amazonaws.com/5c077388b668d806fbaa2a1f-e36c8be2-6058-4e46-aa9f-334750c6e58a.png 300x65) " FOLDED="false" POSITION="right" ID="fd799377221743d186720df4107e8080">
                    <edge COLOR="#eea979"/>
                    <font NAME="Helvetica" SIZE="17"/>
                </node>
            </node>
        </node>
    </x-coggle-rootnode>
</map>