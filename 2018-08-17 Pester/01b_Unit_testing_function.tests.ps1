describe 'Add-One' {

    context 'Testing basic math' {

        $TestNumber = 1
        $result = Add-One -Number $TestNumber

        it 'should return 2' {
            $result | should be 2
        }
    }
}