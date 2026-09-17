function max (
    [parameter(Mandatory = $true)] $arr
) {
    return ($arr | measure -max).maximum
}